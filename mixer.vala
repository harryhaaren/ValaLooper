
namespace Audio
{
	public class Mixer
	{
		private Gee.ArrayList <Sample> sampleArray;
		private Sequencer* sequencer;
		
		public Mixer()
		{
			stdout.printf("Creating audio mixer...\t\t\t");
			sampleArray = new Gee.ArrayList<Sample>();
			
			var x =  new Sample();
			x.load_sample("snare.wav");
			sampleArray.add(x);
			
			stdout.printf("Done!\n");
		}
		
		public void setSequencer(Sequencer* inSequencer)
		{
			sequencer = inSequencer;
		}
		
		~Mixer()
		{
		}
		
		public void addSampler()
		{
			var x =  new Sample();
			x.load_sample("snare.wav");
			sampleArray.add(x);
			
			stdout.printf("sampleArray.length: %i\n",sampleArray.size);
		}
		
		public int process(Jack.NFrames frameNum, Jack.NFrames nframes,ref float* inputBuffer,ref float* outputBufferL,ref float* outputBufferR )
		{
			float temp = 0;
			
			//stdout.printf("FrameNum: %u\n",(uint32)frameNum);
			
			// var sequencerData = 
			sequencer->process(frameNum, nframes);
			
			for(int i = 0; i < (uint32) nframes; i++)
			{
				
			}
			
			return 0;
		}
		
		
	} // class Jack
}


