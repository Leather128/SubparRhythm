package util;

import flixel.graphics.FlxGraphic;
import openfl.media.Sound;

/**
	Class that holds all of the cached data because
	HaxeFlixel's default caching is garbage
 */
class Cache
{
	/**
		Cache for storing OpenFL Sounds.
	 */
	public static var soundCache:Map<String, Sound> = [];

	/**
		Cache for storing FlxGraphics.
	 */
	public static var imageCache:Map<String, FlxGraphic> = [];

	/**
		Adds a specific `value` to a `key` in the chosen `cacheName`
		@param key Map key used to cache `value`
		@param value The actual data being cached
		@param cacheName Name / ID of the cache being used
	 */
	public static function addToCache(key:String, value:Dynamic, cacheName:String)
	{
		var cache = convertStringToCache(cacheName);

		cache.set(key, value);
	}

	/**
		Gets data from `cacheName` using the `key` as the key for the map.
		@param key Map key used to get the cached value
		@param cacheName Name / ID of the cache that is being grabbed from
	 */
	public static function getFromCache(key:String, cacheName:String)
	{
		var cache = convertStringToCache(cacheName);

		return cache.get(key);
	}

	/**
		Converts `name` into the actual usable map for caching.
		@param name Name / ID of the cache
	 */
	public static function convertStringToCache(name:String):Dynamic
	{
		switch (name.toLowerCase())
		{
			case "sound":
				return soundCache;
			case "image":
				return imageCache;
			default:
				return new Map<String, String>();
		}
	}

	/**
		Clears the caches because memory leaks are bad
	 */
	public static function clearCaches()
	{
		for (key in Cache.imageCache.keys())
		{
			if (key != null)
			{
				lime.utils.Assets.cache.clear(key);
				openfl.Assets.cache.clear(key);
				Cache.imageCache.remove(key);
			}
		}

		Cache.imageCache = [];

		for (key in Cache.soundCache.keys())
		{
			if (key != null)
			{
				openfl.Assets.cache.clear(key);
				Cache.soundCache.remove(key);
			}
		}

		Cache.soundCache = [];
	}
}
