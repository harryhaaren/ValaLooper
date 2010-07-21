
using Audio;
using Widget;

Jack.Client client;
unowned Jack.Port master_l;
unowned Jack.Port master_r;
unowned Jack.Port input_port;

Sample recordSample;

double percentComplete;

Audio.Volume recordVolume;

Gtk.HScale   slider;
WaveView     recView;

bool record;

namespace Audio
{
	public class Volume
	{
		public float volume;
		
		public Volume() {}
		
		public void set_volume(float inVol)
		{
			volume = inVol;
		}
		public float get_volume()
		{
			return volume;
		}
		
		// there's a chance were passed a "null" array, so pass by ref
		public void process( ref float[] input)
		{
			
			for( int i = 0; i < input.length; i++)
			{
				input[i] = (float) (input[i] * this.volume);
			}
		}
	}
}

public int ProcessCallback(Jack.NFrames nframes)
{
	// get buffer data
	var input    = (float*) input_port.get_buffer(nframes);
	
	if (record)
	{
		// copy data to wherever
		for(int i = 0; i < (uint32) nframes; i++)
		{
			recordSample.add_sample(input[i]);
		}
	}
	
	// Output:
	var buffer_l = (float*) master_l.get_buffer(nframes);
	var buffer_r = (float*) master_r.get_buffer(nframes);
	
	float[] recordSamp = {};
	
	if (!record)
	{
		recordSamp = recordSample.get_nframes(nframes);
	}
	
	percentComplete = recordSample.get_complete();
	//stdout.printf("%f\t%s\n" , percentComplete,(record)?"ON":"OFF");
	
	recView.set_complete(percentComplete); // waveView update "line"
	
	recordVolume.process( ref recordSamp );
	
	for(int i = 0; i < (uint32) nframes; i++)
	{
		float temp = 0; // snare[i] + kick[i];
		
		if (!record)
			temp += recordSamp[i];
		
		buffer_l[i] = temp;
		buffer_r[i] = temp;
	}
	
	return 0;
}

public void setSnareVolume()
{
	recordVolume.set_volume((float)slider.get_value());
	stdout.printf("Record Vol: %f\n",recordVolume.get_volume());
}

public void indexZero()
{
	stdout.printf("Snare CLick\n");
	recordSample.play();
}

public void recordToggle()
{
	if (!record)
		recordSample.clear(); // only clear sample when recording new one
	
	recView.set_sample( recordSample.get_sample() );
	recView.redraw();
	
	stdout.printf("Record was %s",(record)?"ON":"OFF");
	record = !record;
	stdout.printf(" and is now %s\n",(record)?"ON":"OFF");
	

}

public void playRec()
{
	stdout.printf("RECORD CLick\n");
	recordSample.play();
}

public int main(string[] args)
{
	Gtk.init(ref args);
	
	percentComplete = 0.0;
	record = false; // for recordSample class
	
	// load samples into "Sample" objects (init objects first)
	recordSample = new Sample();
	recordSample.clear();
	
	// Set up GTK
	var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	var vbox   = new Gtk.VBox(false,5);
	var sampleBox   = new Gtk.HBox(true,5);
	
	slider = new Gtk.HScale.with_range (0, 1.5, 0.001);
	slider.value_changed.connect(setSnareVolume);
	
	var playRecButton = new Gtk.Button.with_label("Play Recording");
	var recordButton = new Gtk.Button.with_label("Record");
	
	recView = new WaveView();			// already declared
	recordVolume = new Audio.Volume();
	
	recView.set_sample( recordSample.get_sample() );
	
	window.add(vbox);
	vbox.add(sampleBox);
	sampleBox.add(recView);
	
	vbox.add(slider);
	vbox.add(playRecButton);
	vbox.add(recordButton);
	
	window.set_default_size(300,120);
	window.show_all();
	playRecButton.clicked.connect(playRec);
	recordButton.clicked.connect(recordToggle);
	window.destroy.connect(Gtk.main_quit);
	
	// Set up JACK:
	stdout.printf("Attempting to connect to JACK...\t\t\t");
	Jack.Status status;
	client = Jack.Client.open("ValaClient",Jack.Options.NoStartServer, out status);
	uint32 bufSize = 0;
	
	while (client == null) // loop to check JACK is running
	{
		stdout.printf("Failed.\n");
		var dialog = new Gtk.MessageDialog (new Gtk.Window(), Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK_CANCEL, ("JACK server is not started, will I start it for you?"));
		var response = dialog.run();
		
		if ( response == Gtk.ResponseType.OK )
		{
			stdout.printf("Attempting to connect to JACK...\t\t\t");
			// Start JACK server, will hop out of loop if opened successfully
			client = Jack.Client.open("ValaClient",Jack.Options.NullOption, out status);
			dialog.destroy();
		}
		else
		{
			stdout.printf("Quitting now.\n");
			dialog.destroy();
			return -1; // quit program
		}
	}
	
	stdout.printf("Done!\n"); // connected to JACK
	
	// will segFault here if JACK is not running...
	bufSize = client.get_buffer_size();
	stdout.printf("Jack Client created\t\t\tOk!\n");
	
	master_l = client.port_register("master_out_L", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsOutput, bufSize);
	master_r = client.port_register("master_out_R", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsOutput, bufSize);
	input_port = client.port_register("input_port", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsInput, bufSize);
	
	// register callback
	client.set_process_callback(ProcessCallback);
	
	client.activate();
	// connect ports:
	string[] ports = client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsInput);
	client.connect(master_l.name() , ports[0]);
	client.connect(master_r.name() , ports[1]);
	
	string[] outPorts = client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsOutput);
	
	for (int i = 0; i < outPorts.length; i++)
	{
		stdout.printf("%s\n", outPorts[i]);
	}
	
	client.connect( outPorts[2], input_port.name());
	
	
	// Run GTK
	Gtk.main();
	
	// Take down JACK
	client.deactivate();
	
	return 0;
}
