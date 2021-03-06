namespace Audio
{
	public class Sample
	{
		private int index;
		private float[] array;
		private SndFile.File file;
		
		public Sample()
		{
			this.array = new float[1];
			this.array[0] = (float)0.0;
		}
		
		public void play(int sampleNum) // for "sampler" class.. HACK!
		{
			this.index = 0;
		}
		public void play_()
		{
			this.index = 0;
		}
		public bool load_sample(string name)
		{
			stdout.printf("load_sample(%s)",name);
			
			SndFile.Info info;
			this.file = SndFile.File.open(name,SndFile.FileMode.READ, out info);
			
			this.array = new float[info.frames];
			this.file.read_float( &this.array[0], info.frames);
			
			stdout.printf("%s: %i\n", name , (int) info.frames);
			this.index = (int)info.frames;
			return true;
		}
		public float[] get_nframes(Jack.NFrames nframes) // nframe parameter
		{
			// create temp array
			float[] tempArray = new float[ (uint32)nframes ];
			
			// copy contents of real array @ index to tempArray
			for ( int tempIndex =0 ; this.index < this.array.length && tempIndex < (int) nframes; this.index++)
				tempArray[tempIndex++] = this.array[this.index] ;
			
			
			// Loops sample
			//if ( this.index >= this.array.length ) {	this.index = 0; }
			
			return tempArray;
		}
		
		public float get_single_sample()
		{
			if (this.array.length == 0) // no sample loaded, so CANNOT access buffer without segfault
			{
				return (float) 0.0;
			}
			
			if ( this.index >= this.array.length ) // check bounds of sample & loop
			{
				this.index = 0;
			}
			
			return this.array[this.index++];
		}
		
		public float[] get_sample()
		{
			float[] tempArray = new float[this.array.length];
			
			for(int i = 0; i < array.length; i++)
				tempArray[i] = this.array[i];
			
			return tempArray;
		}
		public void clear()
		{
			array = {};
		}
		public void add_sample(float inSample)
		{
			array += inSample;
		}
		public double get_complete()
		{
			if (array.length == 0)
				return 0.0;
			
			return (double) index / array.length;
		}
	}
}

