package com.roguedevelopment.objecthandles
{
	import classes.Singleton;
	
	import flash.display.DisplayObject;
	
	import mx.core.Container;
	import mx.core.IVisualElement;
	
	import spark.components.Group;

	/**
	 * A class that knows how to add and remove children from a Flex 3 based component using
	 * either addElement, addChild or rawChildren.addChild
	 * 
	 * This class could always be used instead of Flex3ChildManager since it understand both,
	 * but it won't compile under the Flex 3 SDK.
	 **/
	public class Flex4ChildManager implements IChildManager
	{
		
		[Bindable] public var singleton:Singleton = Singleton.getInstance();
		
		public function addChild(container:Object, child:Object):void
		{
			if( container is Group )
			{
				(container as Group).addElement( child as IVisualElement );
			}
			else if( container is Container )
			{
				(container as Container).rawChildren.addChild(child as DisplayObject);
			}			           
			else
			{
				container.addChild( child as DisplayObject);
			}
		}
		
		public function removeChild(container:Object, child:Object):void
		{
			
			if( container is Group )
			{
				
				var failed:Boolean = false;
				try {
					
					(container as Group).removeElement( child as IVisualElement );
					
				} catch (err:Error) {
					
					try {
						
						if (container.id == "normal") {
							container = singleton.selected_spread_editor.ontopelementcontainer;
							(container as Group).removeElement( child as IVisualElement );
						} else {
							container = singleton.selected_spread_editor.elementcontainer;
							(container as Group).removeElement( child as IVisualElement );	
						}
						
					} catch (err:Error) {
						//
					}
				}
			}
			else if( container is Container )
			{
				(container as Container).rawChildren.removeChild(child as DisplayObject);
			}
			else
			{
				container.removeChild( child as DisplayObject);
			}
		}
	}
}