module aurora.rendering.application;

import core.sync.rwmutex;

import aurora.rendering.window;

version(Windows) {
import aurora.rendering.directx.window;
}

extern(C) void onStartup(Application app);
extern(C) void onShutdown();

public struct ApplicationHandle
{
    private void* _handle;

    package this(void* handle)
    {
        this._handle = handle;
    }

    package @property void* Value() { return _handle; }

    public size_t toHash() const nothrow @safe { return cast(size_t)_handle; }
    public const bool opEquals(ref const ApplicationHandle t) { return toHash() == t.toHash(); }
}
alias ApplicationHandle WindowHandle;

public enum ShutdownMode
{
    Explicit,
    LastWindowClosed,
    MainWindowClosed
}

public class Application
{
    private static Application _application;
    public static @property Application Current() { return _application; }

    private ReadWriteMutex _windowMutex;

    private ApplicationHandle _appHandle;
    package @property ApplicationHandle Handle() { return _appHandle; }

    private Window _mainWindow;
    public @property Window MainWindow() { return _mainWindow; }
    public @property Window MainWindow(Window mainWindow) { return _mainWindow = mainWindow; }
     
    private Window[WindowHandle] _windows;
    public @property immutable(Window[]) Windows() { 
        return cast(immutable)_windows.values; 
    }

    private immutable(string[]) _args;
    public @property immutable(string[]) CommandLineArgs() { return _args; }

    private int _exitCode;
    public @property int ExitCode() { return _exitCode; }
    public @property int ExitCode(int code) { return _exitCode = code; }

    private ShutdownMode _exitMode;
    public @property ShutdownMode ExitMode() { return _exitMode; }
    public @property ShutdownMode ExitMode(ShutdownMode mode) { return _exitMode = mode; }

    public bool delegate(Throwable e) nothrow ApplicationUnhandledExceptionEvent;
    package bool OnApplicationUnhandledException(Throwable e) { 
        if (ApplicationUnhandledExceptionEvent !is null) {
            return ApplicationUnhandledExceptionEvent(e);
        } else {
            return false;
        }
    }

    package this(string[] args, ApplicationHandle handle)
    {
        this._args = cast(immutable)args;
        this._appHandle = handle;
        this._application = this;
        this._exitCode = 0;
        this._windowMutex = new ReadWriteMutex(ReadWriteMutex.Policy.PREFER_WRITERS);
    }

    public Window CreateWindow(string Title)
    {
        _windowMutex.writer.lock();
        scope(exit) _windowMutex.writer.unlock();

        version(Windows) {
            Window window = new WindowsWindow(Title);
            _windows[window.Handle] = window;
            _windows.rehash();
            return window;
        }
    }

    package void RemoveWindow(WindowHandle window)
    {
        _windowMutex.writer.lock();
        scope(exit) _windowMutex.writer.unlock();

        _windows.remove(window);
        _windows.rehash();
    }

    package Window GetWindow(WindowHandle handle)
    {
        _windowMutex.reader.lock();
        scope(exit) _windowMutex.reader.unlock();

        return _windows[handle];
    }

    package void Startup()
    {
        onStartup(this);
    }

    public void Shutdown(int exitCode)
    {
        this._exitCode = exitCode;
        onShutdown();
    }
}
