import flash.events.Event;

protected function cbHideSelected_changeHandler(event:Event):void
{
	
	if (event.currentTarget.selected) {
		
		for (var x:int=singleton.userphotosforupload.length-1; x > -1; x--) {
			if (singleton.userphotosforupload.getItemAt(x).usedinstoryboard) {
				singleton.userphotosforuploadhidden.addItem(singleton.userphotosforupload.getItemAt(x));
				singleton.userphotosforupload.removeItemAt(x);
			}
			
		}
		
	} else {
		
		for (x=singleton.userphotosforuploadhidden.length-1; x > -1; x--) {
			singleton.userphotosforupload.addItem(singleton.userphotosforuploadhidden.getItemAt(x));
			singleton.userphotosforuploadhidden.removeItemAt(x);
		}
		
	}
}