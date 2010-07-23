
namespace Audio
{
	public class Mixer
	{
		private Gee.ArrayList <Sample> sampleArray;
		
		public Mixer()
		{
			stdout.printf("Creating audio mixer...\t\t\t");
			sampleArray = new Gee.ArrayList<Sample>();
			
			var x =  new Sample();
			x.load_sample("snare.wav");
			sampleArray.add(x);
			
			stdout.printf("Done!\n");
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
		
		public int process(Jack.NFrames nframes,ref float* inputBuffer,ref float* outputBuffer )
		{
			float temp = 0;
			
			for(int i = 0; i < (uint32) nframes; i++)
			{
				for (int sampleNum = 0; sampleNum < sampleArray.size-1; sampleNum++)
				{
					temp += sampleArray[sampleNum].get_single_sample();
				}
				outputBuffer[i] = temp;
			}
			
			return 0;
		}
		
		
	} // class Jack
}


