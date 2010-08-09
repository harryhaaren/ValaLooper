
namespace Audio
{
	public class Engine
	{
		private int bpm;
		public  Mixer		mixer;
		private JackClient	jackClient;
		private Sequencer	sequencer;
		private Sample		sample;
		
		public Engine()
		{
			stdout.printf("Creating audio engine...\n");
			mixer = new Audio.Mixer();
			jackClient= new Audio.JackClient();
			jackClient.setMixer(mixer);
			jackClient.registerPorts();
			jackClient.activate();
			
			// should be "sampler"
			sample = new Sample();
			sample.load_sample("snare.wav");
			
			uint32 sampleRate = jackClient.getSampleRate();
			
			bpm = 120;
			
			stdout.printf("Engine BPM:%i\n", bpm);
			
			sequencer = new Sequencer(sampleRate,bpm);
			sequencer.signal_playSample.connect(sample.play);
			
			jackClient.setSequencer(sequencer); // after jack is activated... :-(
			
			mixer.setSample(sample); // we should be adding a "samplER" not a sampl"e" here.
			
			
			stdout.printf("Engine Sample rate:%u\n",(uint32)sampleRate);
			
			jackClient.connectPorts();
			
			stdout.printf("Engine running!\n");
		}
		
		public void startTransport() { jackClient.startTransport(); }
		public void stopTransport () { jackClient.stopTransport() ; }
		//public void updateBpm (int inBpm) { sequencer.updateBpm(bpm); }
		
		~Engine()
		{
			
		}
	} // class Engine
}
