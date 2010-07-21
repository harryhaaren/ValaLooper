
using Audio;
using Widget;

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

public int main(string[] args)
{
	Gtk.init(ref args);
	
	// creating checks if JACK server running
	JackClient client = new JackClient();
	
	Sample recordSample;
	
	// load samples into "Sample" objects (init objects first)
	recordSample = new Sample();
	recordSample.clear();
	
	// Set up GTK
	var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	var vbox   = new Gtk.VBox(false,5);
	var sampleBox   = new Gtk.HBox(true,5);
	var slider = new Gtk.HScale.with_range (0, 1.5, 0.001);
	
	//slider.value_changed.connect(null);
	
	var playRecButton = new Gtk.Button.with_label("Play Recording");
	var recordButton = new Gtk.Button.with_label("Record");
	
	var recView = new WaveView();			// already declared
	
	recView.set_sample( recordSample.get_sample() );
	
	window.add(vbox);
	vbox.add(sampleBox);
	sampleBox.add(recView);
	
	vbox.add(slider);
	vbox.add(playRecButton);
	vbox.add(recordButton);
	
	window.set_default_size(300,120);
	window.show_all();
	// playRecButton.clicked.connect(<funcNameHere>);
	window.destroy.connect(Gtk.main_quit);
	
	// Run GTK
	Gtk.main();
	
	return 0;
}
