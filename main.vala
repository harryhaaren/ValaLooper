
using Gui;		// contains all GUI classes
using Audio;	// contains all Engine classes

namespace Audio
{
	public class Volume
	{
		public float volume;
		
		public Volume() {}
		
		public void set_volume(float inVol)
		{
			volume = inVol;
		}
		public float get_volume()
		{
			return volume;
		}
		
		// there's a chance were passed a "null" array, so pass by ref
		public void process( ref float[] input)
		{
			
			for( int i = 0; i < input.length; i++)
			{
				input[i] = (float) (input[i] * this.volume);
			}
		}
	}
}

public void callbackHere()
{
	stdout.printf("In addSampler callback");
}

public int main(string[] args)
{
	// Initialize GTK
	Gtk.init(ref args);
	
	// create engine here, will setup up JACK & Mixer objects
	Audio.Engine engine = new Audio.Engine();
	
	// Set up GTK
	Gui.MainWindow mainWin = new Gui.MainWindow();
	
	// Connect signals from GUI to engine
	mainWin.signal_addSampler.connect( engine.mixer.addSampler );
	
	// Run GTK
	Gtk.main();
	
	return 0;
}
