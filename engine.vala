
namespace Audio
{
	public class Engine
	{
		private int bpm;
		public  Mixer		mixer;
		private JackClient	jackClient;
		private Sequencer	sequencer;
		
		public Engine()
		{
			stdout.printf("Creating audio engine...\n");
			mixer = new Audio.Mixer();
			jackClient= new Audio.JackClient();
			jackClient.setMixer(mixer);
			jackClient.registerPorts();
			jackClient.activate();
			
			uint32 sampleRate = jackClient.getSampleRate();
			
			bpm = 120;
			
			stdout.printf("Engine BPM:%i\n", bpm);
			
			sequencer = new Sequencer(sampleRate,bpm);
			mixer.setSequencer(sequencer); // after jack is activated... :-(
			
			
			stdout.printf("Engine Sample rate:%u\n",(uint32)sampleRate);
			
			jackClient.connectPorts();
			
			stdout.printf("Engine running!\n");
		}
		
		~Engine()
		{
			
		}
	} // class Engine
}
