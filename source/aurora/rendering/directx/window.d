module aurora.rendering.directx.window;
version(Windows):

import core.runtime;
import core.sys.windows.windows;
import std.utf;

import aurora.rendering.types;
import aurora.rendering.window;
import aurora.rendering.application;

public class WindowsWindow : Window
{
    private string title;
    public override @property string Title();
    public override @property string Title(string title);

    public this(string title) {
        super();
        this.title = title;

        WNDCLASSW wndclass;
        wndclass.style         = CS_HREDRAW | CS_VREDRAW;
        wndclass.lpfnWndProc   = &WndProc;
        wndclass.cbClsExtra    = 0;
        wndclass.cbWndExtra    = 0;
        wndclass.hInstance     = Application.Current.Handle.Value;
        wndclass.hIcon         = LoadIconW(null, IDI_APPLICATION);
        wndclass.hCursor       = LoadCursorW(null, IDC_ARROW);
        wndclass.hbrBackground = cast(HBRUSH)GetStockObject(WHITE_BRUSH);
        wndclass.lpszMenuName  = null;
        wndclass.lpszClassName = toUTF16z(this.Id);

        if(!RegisterClassW(&wndclass))
            MessageBoxW(null, toUTF16z("This program requires Windows NT!"), toUTF16z(this.Id), MB_ICONERROR);

        auto _handle = CreateWindowW(toUTF16z(this.Id), toUTF16z(this.Title), WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX | WS_SYSMENU | WS_VISIBLE, Location.X, Location.Y, this.Extent.Width, this.Extent.Height, HWND_DESKTOP, null, Application.Current.Handle.Value, null);
        if(_handle is null)
            MessageBoxW(null, toUTF16z("Unable to Create Window"), toUTF16z("Error"), MB_OK | MB_ICONEXCLAMATION);

        this.Handle = WindowHandle(_handle);

        Show();
    }

    public override void Hide() {
        ShowWindow(Application.Current.Handle.Value, SW_HIDE);
    }

    public override void Minimize() {
        ShowWindow(Application.Current.Handle.Value, SW_MINIMIZE);
    }

    public override void Maximize() {
        ShowWindow(Application.Current.Handle.Value, SW_MAXIMIZE);
    }

    public override void Restore() {
        ShowWindow(Application.Current.Handle.Value, SW_RESTORE);
    }

    public override void Show() {
        ShowWindow(Application.Current.Handle.Value, SW_SHOW);
        UpdateWindow(Application.Current.Handle.Value);
    }

    public override void Close() {
        SendMessageA(Application.Current.Handle.Value, WM_CLOSE, 0, 0);
    }

    private LRESULT internalWndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow
    {
        try {
        switch (message)
        {
            case WM_CLOSE:
                DestroyWindow(hwnd);
                return 0;

            case WM_DESTROY:
                Application.Current.RemoveWindow(this.Handle);
                return 0;

            default: return DefWindowProcW(hwnd, message, wParam, lParam);
        }
        } catch (Throwable e) { }

        return DefWindowProcW(hwnd, message, wParam, lParam);
    }
}

extern(Windows) LRESULT WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam) nothrow {
    try {
        auto window = cast(WindowsWindow)Application.Current.GetWindow(WindowHandle(hwnd));
        return window.internalWndProc(hwnd, message, wParam, lParam);
    }
    catch (Throwable e) { }
    return 0;
}