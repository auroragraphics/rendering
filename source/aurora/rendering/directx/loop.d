module aurora.rendering.directx.loop;
version(Windows):

import core.runtime;
import core.sys.windows.windows;
import std.conv;
import std.utf;
import std.string;

import aurora.rendering.application;

private void initializeRenderLoop()
{

}

private void renderLoop()
{

}

extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int result;
    Application app = null;
    
    try
    {
        Runtime.initialize();

        auto args = to!string(lpCmdLine).split(" ");
        auto appHandle = ApplicationHandle(hInstance);
        app = new Application(args, appHandle);
        app.Startup();

        while (1)
        {
            //Use PeekMessage so we don't stall while waiting for a message
            MSG msg = { };
            if(PeekMessageW(&msg, null, 0, 0, PM_REMOVE)) {
                if(msg.message == WM_QUIT) {
			        break;
                }
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
        }

        app.Shutdown(0);
        Runtime.terminate();
    }
    catch (Throwable e) // catch any uncaught exceptions
    {
        app.OnApplicationUnhandledException(e);
        MessageBoxW(null, toUTF16z(e.toString()), toUTF16z("Error"), MB_OK | MB_ICONEXCLAMATION);
        result = 0;     // failed
    }
    finally
    {
        Runtime.terminate();
    }
    
    return result;
}