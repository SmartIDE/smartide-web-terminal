<template>
  <div class="dialog-modal" v-show="visible" @click.self="() => $emit('update:visible', false)">
    <div class="config-container">
      <el-tabs v-model="activeName" @tab-click="handleClick">
        <el-tab-pane label="Docker" name="first">
          <el-select v-model="dockers" placeholder="请选择Docker" style="width: 100%">
            <el-option v-for="item in dockers" :key="item.containerId" :label="item.containerName" :value="item.containerId"></el-option>
          </el-select>
          <div v-if="theme">
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script>
import io from "socket.io-client";
import uuidv4 from "uuid/v4";

export default {
  name: "DockerModal",
  props: {
    visible: Boolean
  },
  data() {
    return {
      dockers: null,
      docker: "",
      activeName: "first",
      theme: window.localStorage.getItem("themeName") || null,
      bgimg: window.localStorage.getItem("bgimg") || null
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
    theme(val) {
      window.localStorage.setItem("themeName", val);
      this.$emit("setTheme", xtermTheme[val]);
    }
  },
  methods: {
    getDockerList() {
      //docker ps --format "{ \"containerId\":\"{{.ID}}\",\"containerName\":\"{{.Names}}\"}"
      console.log("获取docker ps");
      let terminalname = "terminal-docker-" + uuidv4();
      let filtration = "filtration" + terminalname;
      let socket = io(window.location.origin + "/terminal", {reconnection: true});
      socket.emit("docker", { name: terminalname, filtration: filtration });
      setTimeout(function() {
        socket.emit(terminalname + "-docker-input", `docker ps --format "${filtration}{ \"containerId\":\"{{.ID}}\",\"containerName\":\"{{.Names}}\" }" \r`);
        //socket.emit(terminalname + "-docker-input", `echo ] | (docker ps --format '{ "containerId" : "{{.ID}}" , "containerName": "{{.Names}}" }' | paste -sd',' && cat) | (echo ${filtration}[ && cat) \r`);
      },2000);
      socket.on(terminalname + "-docker-output", arrayBuffer => {
        console.log(arrayBuffer);
        arrayBuffer.forEach(element => {
          if (element) {
            this.dockers.push(element)
          }
        });
      });
      //socket.close();
    },
    handleUpload(e) {
      let file = event.target.files[0];
      var reader = new FileReader();
      reader.readAsDataURL(file);
      reader.onload = e => {
        this.bgimg = e.target.result;
        window.localStorage.setItem("bgimg", e.target.result);
      };
    }
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
  min-width: 640px;
  min-height: 380px;
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

  .theme-colors {
    font-size: 12px;

    .show-color {
      width: 100%;
      height: 24px;
      margin-bottom: 10px;
    }

    .el-col {
      text-align: center;
    }
  }

  .bgimg-btn {
    width: 600px;
    height: 300px;

    img {
      width: 100%;
      height: 100%;
    }
  }
}

.upload-input {
  z-index: 100000;
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  width: 100%;
  font-size: 0;
  opacity: 0;
}
</style>