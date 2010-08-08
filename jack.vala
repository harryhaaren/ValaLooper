
// for dialog box's reporting JACK status
using Gtk;

// from C, to quit if jack isnt running
extern void exit(int exitCode);

namespace Audio
{
	public class JackClient
	{
		private Mixer*  mixer;

		private uint32  bufferSize;
		private Jack.Client client;
		private Jack.Status status;
		private unowned Jack.Port masterL;
		private unowned Jack.Port masterR;
		private unowned Jack.Port inputPort;
		
		public JackClient()
		{
			stdout.printf("Attempting to connect to JACK...\t\t\t");
			client = Jack.Client.open("ValaClient",Jack.Options.NoStartServer, out status);
			
			for(int i = 0; client == null; i++) // loop to check JACK is running
			{
				stdout.printf("Failed.\n");
				
				string message = "JACK server is not started, will I start it for you?";
				if (i > 0) // we've already tried to start JACK but it failed
					message = "JACK server failed to start, please check your JACK settings.\n(Is your soundcard ON and plugged in?)";
				var dialog = new Gtk.MessageDialog (new Gtk.Window(), Gtk.DialogFlags.DESTROY_WITH_PARENT | Gtk.DialogFlags.MODAL, Gtk.MessageType.ERROR, Gtk.ButtonsType.OK_CANCEL, message);
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
					exit(-1);
				}
			}
			
			// here JACK is running, and we can do what we need to
			client.set_process_callback(processCallback);
			bufferSize = client.get_buffer_size();
			stdout.printf("Done!\n"); // connected to JACK
		}
		
		public void setMixer(Mixer* inMixer)
		{
			mixer = inMixer;
		}
		
		public void startTransport() { client.transport_start(); }
		public void stopTransport()  { client.transport_stop();  }
		
		~JackClient()
		{
			// Take down JACK
			client.deactivate();
		}
		
		public void activate()
		{
			// activate client
			client.activate();
		}
		
		public Jack.NFrames getSampleRate()
		{
			return client.get_sample_rate();
		}
		
		public void connectPorts()
		{
			// then connect ports
			string[] ports = client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsInput);
			client.connect(masterL.name() , ports[0]);
			client.connect(masterR.name() , ports[1]);
			
			string[] outPorts = client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsOutput);
			client.connect( outPorts[0], inputPort.name());
		}
		public void registerPorts()
		{
			masterL = client.port_register("master_out_L", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsOutput, bufferSize);
			masterR = client.port_register("master_out_R", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsOutput, bufferSize);
			inputPort = client.port_register("inputPort", Jack.DEFAULT_AUDIO_TYPE, Jack.Port.Flags.IsInput, bufferSize);
		}
		
		private int processCallback(Jack.NFrames nframes)
		{
			// get buffer data
			var inputBuffer    = (float*) inputPort.get_buffer(nframes);
			
			// Output:
			var outputBufferL = (float*) masterL.get_buffer(nframes);
			var outputBufferR = (float*) masterR.get_buffer(nframes);
			
			var frameNum = client.get_current_transport_frame();
			
			Jack.Position pos;
			Jack.TransportState x = client.transport_query(out pos);
			
			if ( x == Jack.TransportState.Rolling)
			{
				// ask mixer to process: it also writes the data to the buffers
				mixer->process(frameNum, nframes,ref inputBuffer, ref outputBufferL, ref outputBufferR);
			}
			else // fill buffers with 0
			{
				float temp = (float) 0.0;
				
				for (int i = 0; i < (int) nframes; i++)
				{
					*outputBufferL = temp;
					*outputBufferR = temp;
				}
			}
			
			return 0;
		}
		
		
	} // class Jack
}


