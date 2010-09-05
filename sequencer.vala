
namespace Audio
{
	public class Sequencer
	{
		private int sampleRate;
		private int bpm;
		private int samplesPerMin;
		private int samplesPerBeat;
		private int beatsDone;
		
		public signal void signal_playSample(int x);
		
		public Sequencer(uint32 inSampleRate, int inBpm)
		{
			if (inBpm == 0)
				stdout.printf("Sequencer(): ERROR: bpm was 0!\n"); 
			
			beatsDone = 0;
			bpm = inBpm;
			sampleRate = (int) inSampleRate;
			samplesPerMin = sampleRate * 60;
			samplesPerBeat= samplesPerMin/bpm;
			stdout.printf("SamplesPerBeat:\t%i",samplesPerBeat);
			
			signal_playSample(0);
		}
		
		public void updateBpm(int inBpm)
		{
			samplesPerBeat= samplesPerMin/inBpm;
			stdout.printf("BPM updated:\t%i",samplesPerBeat);
		}
		
		public void process( uint32 frameNum, uint32 frames )
		{
			uint32 oldModulus = 0;
			
			for (uint32 i = 0; i < frames; i++)
			{
				if ( (frameNum + i) % samplesPerBeat == 0)
				{
					stdout.printf("Beat: %i\n",beatsDone++);
					signal_playSample(0);
				}
				//stdout.printf("%u\t%u\n",oldModulus,frameNum);
				oldModulus = frameNum + i % samplesPerBeat;
			}
		}
		
		~Sequencer()
		{
		}
	} // class Sequencer
}
