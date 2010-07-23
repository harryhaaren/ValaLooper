
namespace Gui
{
	public class MainWindow
	{
		// public signals
		public signal void signal_addSampler(); // definition of the signal
		
		// private attributes
		private Gtk.Window	window;
		private Gtk.VBox	mainBox;
		private Gtk.HBox	menuBox;
		private Gtk.HBox	samplerBox;
		private Gee.ArrayList<Gui.WaveView> waveviewArray;
		
		public MainWindow()
		{
			window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
			mainBox = new Gtk.VBox(false,0);
			menuBox = new Gtk.HBox(false,0);
			window.add(mainBox);
			
			mainBox.add(menuBox);
			
			var button = new Gtk.Button.with_label("Add");
			button.clicked.connect( () => { addSampler(); } );
			menuBox.add(button);
			
			button = new Gtk.Button.with_label("Quit");
			button.clicked.connect( () => { Gtk.main_quit(); } );
			menuBox.add(button);
			
			samplerBox = new Gtk.HBox(true,0);
			mainBox.add(samplerBox);
			
			waveviewArray = new Gee.ArrayList<Gui.WaveView>() ; // create WaveView arraylist
			
			waveviewArray.add( new WaveView() ); // create 1 WaveView
			samplerBox.add( waveviewArray[waveviewArray.size-1] ); // add 1 WaveView
			
			window.set_default_size(300,120);
			window.show_all();
			window.destroy.connect(Gtk.main_quit);
		}
		
		private void addSampler()
		{
			waveviewArray.add(new WaveView());
			samplerBox.add( waveviewArray[waveviewArray.size-1] );
			window.show_all();
			// add a sampler to engine, pass it a pointer to the new widget
			signal_addSampler();
		}
		
		~MainWindow()
		{
		}
	} // class Gui
}
