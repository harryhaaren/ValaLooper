namespace Gui
{
	public class WaveView : Gtk.DrawingArea
	{
		private double  percent; // % of sample played back
		private float[] array;
		
		public WaveView ()
		{
			// Enable the events you wish to get notified about.
			// The 'expose' event is already enabled by the DrawingArea.
			add_events (Gdk.EventMask.BUTTON_PRESS_MASK
					  | Gdk.EventMask.BUTTON_RELEASE_MASK
					  | Gdk.EventMask.POINTER_MOTION_MASK);

			// Set favored widget size
			set_size_request (100, 100);
			
			var time = new TimeoutSource(250);
			time.set_callback(() => { redraw(); return true; });
			time.attach(null);
		}
		
		public void redraw()
		{
			if (this.window == null)
				return;
			
			unowned Gdk.Region region = this.window.get_clip_region ();
			// redraw the cairo canvas completely by exposing it
			this.window.invalidate_region (region, true);
			this.window.process_updates (true);
		}
		
		public void set_complete(double inPercent)
		{
			percent = inPercent;
		}
		
		/* Widget is asked to draw itself */
		public override bool expose_event (Gdk.EventExpose event)
		{
			// Create a Cairo context
			var cr = Gdk.cairo_create (this.window);
			
			// Set clipping area in order to avoid unnecessary drawing
			cr.rectangle (event.area.x, event.area.y,
						  event.area.width, event.area.height);
			cr.clip ();
			
			int width = event.area.width;
			int height= event.area.height;
			
			unowned Gtk.Style style = this.get_style();
			
			// color.<x>  is a uint16: divide by 65535.0 to get 0-1 range
			Gdk.Color color = style.bg[0];
			
			Gdk.cairo_set_source_color(cr,  color);
			
			//cr.set_source_rgb(color.red/65535.0, color.green/65535.0, color.blue/65535.0);
			
			float currentSample = height/2; // should be dead center
			
			
			for (int i = 0; i < this.array.length; i += 20)
			{
				float x = width * ( i / ((float)array.length) );
				
				cr.move_to( x , currentSample ); // current from last time round loop
				
				currentSample = (height/2) - ( array[i] * (height - 10));
				
				cr.line_to( x , currentSample ); // current next one on in the loop
				
				//stdout.printf("i:%i\tx:%f\n",i,x);
			}
			cr.stroke();
			
			cr.move_to(percent * width , 0);
			cr.line_to(percent * width , height);
			cr.set_source_rgb(1.0,0.2,0.0);
			cr.stroke();
			
			return true;
		}
		
		public void set_sample( float[] inArray)
		{
			array = inArray;
			
			stdout.printf("Got sample in WaveView: %i\n", this.array.length);
			
			if (array.length == 0)
			{
				array = { (float)0.5}; // otherwise there's a % by 0 segfault
			}
		}
		
		/* Mouse button got pressed over widget */
		public override bool button_press_event (Gdk.EventButton event)
		{
			stdout.printf("Button Press event: X: %f\tY: %f\t\tType:%i\n",event.x,event.y,(int)event.button);
			return false;
		}
		
		/* Mouse button got released */
		public override bool button_release_event (Gdk.EventButton event)
		{
			// ...
			return false;
		}
		
		/* Mouse pointer moved over widget */
		public override bool motion_notify_event (Gdk.EventMotion event)
		{
			// ...
			return false;
		}
	}
}
