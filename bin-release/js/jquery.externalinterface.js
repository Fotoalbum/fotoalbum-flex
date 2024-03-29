(function($)
{
	$.fn.externalInterface = function(args)
	{
		this.each(function()
		{
			if(typeof(args.method) != 'undefined')
			{
				try
				{
					if(typeof(args.args) != 'undefined')
					{
						var data = this[args.method](args.args);
					}
					else
					{
						var data = this[args.method]();
					}
					
					if(typeof(args.success) != 'undefined')
					{
						args.success(data);
					}
				}
				catch(error)
				{
					if(typeof(args.error) != 'undefined')
					{
						args.error(error);
					}
				}
			}
		});
	
		return this;
	};
})(jQuery);