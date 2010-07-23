
namespace Audio
{
	public class Engine
	{
		public Mixer		mixer;
		private JackClient	jackClient;
		
		public Engine()
		{
			stdout.printf("Creating audio engine...\n");
			mixer = new Audio.Mixer();
			jackClient= new Audio.JackClient();
			jackClient.setMixer(mixer);
			jackClient.registerPorts();
			jackClient.activate();
			stdout.printf("Engine running!\n");
			
			// segfaults, something with jack_port_name, compiler issues warnings.
			//jackClient.connectPorts();
		}
		
		~Engine()
		{
		}
	} // class Jack
}
