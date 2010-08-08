
namespace Audio
{
	public class Mixer
	{
		private Gee.ArrayList <Sample> sampleArray;
		private Sequencer* sequencer;
		private Sample* sample;
		
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
		
		public void setSample(Sample* inSequencer)
		{
			sample = inSequencer;
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
			//stdout.printf("FrameNum: %u\n",(uint32)frameNum);
			
			// var sequencerData = 
			sequencer->process(frameNum, nframes);
			
			//float[] x = sample->get_nframes(nframes);
			
			for(int i = 0; i < (uint32) nframes; i++)
			{
				var temp = sample->get_single_sample();
				
				*outputBufferL = temp;
				*outputBufferR = temp;
			}
			
			return 0;
		}
		
		
	} // class Jack
}


