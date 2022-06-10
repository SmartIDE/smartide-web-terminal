const { option } = require('args');
const pty = require('node-pty');
const os = require('os');
const userhome = require('user-home');
const shell = os.platform() === 'win32' ? 'powershell.exe' : 'bash';

let ptyContainers = {};

module.exports = socket => {
    socket.on('docker', option => {
        let ptyProcess = pty.spawn(shell, ['--login'], {
            name: 'xterm-color',
            cols: option.cols || 80,
            rows: option.rows || 24,
            cwd: option.cwd || userhome,
            env: process.env
        });
        ptyProcess.onData(function(data) {
            if (data.indexOf(option.filtration) == 0) {
                let arr = data.split(option.filtration)
                let retArr = new Array();
                arr.forEach(element => {
                    if (element) {
                        let jsonStr = element.replace('\r\n','').replace('containerId:','"containerId":"').replace(',containerName:','","containerName":"').replace(' }','" }')
                        retArr.push(JSON.parse(jsonStr))
                    }
                });
                socket.emit(option.name + '-docker-output', retArr)
            }
        });
        let username = os.userInfo().username;
        socket.emit(option.name + '-docker-username', username);
        socket.on(option.name + '-docker-input', data => {
            ptyProcess.write(data)
        });
    });
    socket.on('create', option => {
        let ptyProcess = pty.spawn(shell, ['--login'], {
            name: 'xterm-color',
            cols: option.cols || 80,
            rows: option.rows || 24,
            cwd: option.cwd || userhome,
            env: process.env
        });
        ptyProcess.on('data', data => socket.emit(option.name + '-output', data));
        socket.on(option.name + '-input', data => ptyProcess.write(data));
        socket.on(option.name + '-resize', size => {
            ptyProcess.resize(size[0], size[1]);
        });
        socket.on(option.name + '-exit', size => {
            ptyProcess.destroy();
        });
        socket.emit(option.name + '-pid', ptyProcess.pid);
        ptyContainers[option.name] = ptyProcess;
    });
    socket.on('remove', name => {
        socket.removeAllListeners(name + '-input');
        socket.removeAllListeners(name + '-resize');
        socket.removeAllListeners(name + '-exit');
        if (name && ptyContainers[name] && ptyContainers[name].pid) {
            ptyContainers[name].destroy();
            delete ptyContainers[name];
        }
    });
};
