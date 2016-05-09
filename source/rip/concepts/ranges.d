module rip.concepts.ranges;

private
{
	import std.algorithm;
	import std.array;
	import std.range;

	import rip.concepts.color;
	import rip.concepts.surface;
	import rip.concepts.templates;
}

Surface toSurface(Range)(Range r, size_t width, size_t height)
	if (is(ElementType!Range == RGBColor))
{
	Surface surface = new Surface(width, height);
	auto imageArray = r.array;

	auto s = width * height;

	foreach(i; 0..s) {
		surface[i] = imageArray[i];
	}

	return surface;
}

auto createPixels(Range)(Range r)
{
	struct PixelRange
	{
		private RGBColor[] pixels;

		this(Range)(Range r)
			if (is(ElementType!Range == RGBColor))
		{
			pixels = r.array;
		}

		@property
		{
			RGBColor back()
			{
				return pixels.back;
			}

			bool empty()
			{
				return pixels.empty;
			}

			RGBColor front()
			{
				return pixels.front;
			}
		}

		void popFront()
		{
			pixels.popFront();
		}

		void popBack()
		{
			pixels.popBack();
		}

		PixelRange save()
		{
			return this;
		}
	}

	return PixelRange(r);
}


auto createFences(T, U)(Surface surface, T width, U height)
{
	alias Range = typeof(createPixels([RGBColor.init]));

	struct FenceRange(T, U, Range)
		if (allArithmetic!(T, U))
	{
		private Range[] pixelsRange;

		this(T, U)(Surface surface, T width, U height)
			if (allArithmetic!(T, U))
		{
			int halfFenceWidth = cast(int) width / 2;
			int halfFenceHeight = cast(int) height / 2;

			for (int i = 0; i < surface.getHeight!int; i++)
			{
				for (int j = 0; j < surface.getWidth!int; j++)
				{
					ElementType!Range[] fenceAccumulator;

					for (int w = 0; w < cast(int) width; w++)
					{
						for (int h = 0; h < cast(int) height; h++)
						{
							auto indexW = j + (halfFenceWidth - w);
							auto indexH = i + (halfFenceHeight - h);
							if ((indexW < 0) || (indexH >= surface.getArea!int))
							{
								fenceAccumulator ~= new RGBColor(0, 0, 0);
							}
							else
							{
								fenceAccumulator ~= surface[indexW, indexH];
							}
						}
					}

					pixelsRange ~= createPixels(fenceAccumulator);
				}
			}
		}

		@property
		{
			Range back()
			{
				return pixelsRange.back;
			}

			bool empty()
			{
				return (pixelsRange.length == 0);
			}

			Range front()
			{
				return pixelsRange.front;
			}
		}

		void popFront()
		{
			pixelsRange.popFront;
		}

		void popBack()
		{
			pixelsRange.popBack;
		}
	}

	return FenceRange!(T, U, Range)(surface, width, height);
}
