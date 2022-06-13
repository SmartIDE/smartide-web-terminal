<template>
  <div class="dialog-modal" v-show="visible" @click.self="() => $emit('update:visible', false)">
    <div class="config-container">
      <el-tabs v-model="activeName" @tab-click="handleClick">
        <el-tab-pane label="Docker" name="docker">
          <el-select v-model="docker" @change="getContainerName" placeholder="请选择Docker" style="width: 100%" :popper-append-to-body="false">
            <el-option v-for="item in dockers" :key="item.containerId" :label="`${currentUser}@${item.containerName}(${item.containerId})`" :value="item.containerId"></el-option>
          </el-select>
          <div v-if="currentUser != 'root'">
            <p class="title">
              是否总是使用root用户<el-switch style="    margin-left: 10px;" v-model="isRootUser" />
            </p>
          </div>
        </el-tab-pane>
      </el-tabs>
      <div slot="footer" class="dialog-footer">
        <el-button @click="() => $emit('update:visible', false)">取 消</el-button>
        <el-button type="primary" @click="handleNewTerminal">确 定</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import io from 'socket.io-client';
import uuidv4 from 'uuid/v4';

export default {
  name: "DockerModal",
  props: {
    visible: Boolean
  },
  data() {
    return {
      currentUser: "root",
      dockers: null,
      docker: "",
      dockerName: "",
      activeName: "docker",
      isRootUser: false
    };
  },

  computed: {
    colors() {
      if (this.theme) {
        return xtermTheme[this.theme];
      } else {
        return null;
      }
    }
  },
  watch: {
    // docker(val) {
    //   console.log(val)
    //   this.$emit("setDocker", val);
    // }
  },
  methods: {
    //获取当前服务器docker列表
    getDockerList() {
      let terminalname = "terminal-docker-" + uuidv4();
      let filtration = "filtration" + terminalname;
      let socket = io(window.location.origin + "/terminal", {reconnection: true});
      socket.emit("docker", { name: terminalname, filtration: filtration });
      setTimeout(function() {
        socket.emit(terminalname + "-docker-input", `sudo docker ps --format "${filtration}{ \"containerId\":\"{{.ID}}\",\"containerName\":\"{{.Names}}\" }" \r`);
      },2000);
      socket.on(terminalname + "-docker-output", arrayBuffer => {
        arrayBuffer.forEach(element => {
          if (element) {
            this.dockers.push(element)
          }
        });
      });
      socket.on(terminalname + "-docker-username", username => {
        if (username) {
          this.currentUser = username
        }
      });
      setTimeout(function() {
        socket.close();
      }, 10000);
    },
    //value的是是:value的值
    getContainerName(value) {
      this.dockers.forEach(item => {
        if(item.containerId == value){
          this.dockerName = item.containerName;
        }
      })
    }, 
    // handleClick(tab, event) {
    //   console.log(this.activeName)
    //   console.log(tab, event);
    // },
    //增加docker terminal
    handleNewTerminal(e) {
      if (this.activeName) {
        var obj = {};
        obj.id = this.docker;
        obj.name = this.dockerName;
        obj.type = this.activeName;
        obj.user = this.isRootUser ? 'root' : this.currentUser;
        this.$emit("selectedDocker", obj);
        this.$emit('update:visible', false);
      }
    },

  },
  mounted() {
    if (!this.dockers) {
      this.dockers = new Array()
    }
    this.getDockerList();
  },
};
</script>

<style lang="less" scoped>
.dialog-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  z-index: 2000;
  text-align: center;
  background-color: rgba(0, 0, 0, 0.1);
  color: #000;

  &::after {
    content: "";
    display: inline-block;
    height: 100%;
    width: 0;
    vertical-align: middle;
  }
}
.config-container {
  position: relative;
  display: inline-block;
  min-width: 360px;
  min-height: 200px;
  padding: 10px 10px 20px;
  vertical-align: middle;
  background-color: #fff;
  border-radius: 4px;
  border: 1px solid #ebeef5;
  font-size: 18px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
  text-align: left;
  overflow: hidden;
  backface-visibility: hidden;

  .btn-close {
    position: absolute;
    top: 5px;
    right: 10px;
    width: 10px;
    height: 10px;
    cursor: pointer;
  }

  .title {
    font-size: 14px;
  }

  .dialog-footer {
    position: absolute;
    bottom: 10px;
    right: 10px;
    width: 100%;
    text-align: right;
  }
}

</style>