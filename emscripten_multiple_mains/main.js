// This is to simply render index.html in an electron app,
// which crashes the renderer process and is tricky to debug.
// Run this command to try it:
//     ELECTRON_ENABLE_LOGGING=1 electron .
//
// Note that without adding `ELECTRON_ENABLE_LOGGING=1`, the
// dev tools disconnect and there is no error, making it really
// tricky to debug.

const { app, BrowserWindow } = require('electron/main')

const createWindow = () => {
  const win = new BrowserWindow({
    width: 800,
    height: 600
  })

  win.loadFile('index.html')
}

app.whenReady().then(() => {
  createWindow()

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      createWindow()
    }
  })
})

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit()
  }
})
