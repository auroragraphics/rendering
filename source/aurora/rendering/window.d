module aurora.rendering.window;

import std.uuid;

import aurora.rendering.types;
import aurora.rendering.application;

public abstract class Window
{
    private string _id;
    package @property string Id() { return _id; }

    private WindowHandle _windowHandle;
    public @property WindowHandle Handle() { return _windowHandle; }
    protected @property WindowHandle Handle(WindowHandle handle) { return _windowHandle = handle; }

    private Point _location;
    public @property Point Location() { return _location; }
    public @property Point Location(Point location) { return _location = location; }

    private Size _size;
    public @property Size Extent() { return _size; }
    public @property Size Extent(Size size) { return _size = size; }

    public abstract @property string Title();
    public abstract @property string Title(string title);

    protected this() {
        this._id = randomUUID().toString();
    }

    public abstract void Hide();
    public abstract void Minimize();
    public abstract void Maximize();
    public abstract void Restore();
    public abstract void Show();
    public abstract void Close();

}