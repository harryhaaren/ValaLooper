using Gtk;

namespace Audio
{
	public class JackClient
	{
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
					// quit(0);
				}
			}
			
			// here JACK is running, and we can do what we need to
			client.set_process_callback(processCallback);
			bufferSize = client.get_buffer_size();
			stdout.printf("Done!\n"); // connected to JACK
		}
		
		~JackClient()
		{
			// Take down JACK
			client.deactivate();
		}
		
		public void activate()
		{
			// activate client
			client.activate();
			
			// then connect ports
			string[] ports = (string[]) client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsInput);
			client.connect(masterL.name() , ports[0]);
			client.connect(masterR.name() , ports[1]);
			
			string[] outPorts = client.get_ports("", "", Jack.Port.Flags.IsPhysical | Jack.Port.Flags.IsOutput);
			client.connect( outPorts[2], inputPort.name());
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
			var input    = (float*) inputPort.get_buffer(nframes);
			
			// Output:
			var buffer_l = (float*) masterL.get_buffer(nframes);
			var buffer_r = (float*) masterR.get_buffer(nframes);
			
			
			for(int i = 0; i < (uint32) nframes; i++)
			{
				float temp = 0;
				
				temp = (float) (input[i] * 1.5); // copy input to outputs
				
				buffer_l[i] = temp;
				buffer_r[i] = temp;
			}
			
			return 0;
		}
		
		
	} // class Jack
}


