module rip.color.color;

import std.algorithm;

class Color(Type, size_t N) {
protected:

    void opIndexAssign(T = Type)(T value, size_t index) {
        static if(is(T == Type)) {
            data[index] = value;
        }
        else {
            data[index] = cast(Type) clamp(value, Type.min, Type.max);
        }
    }

    Type opIndex(size_t index) const {
        return data[index];
    } 

private:
    Type[N]     data;
}