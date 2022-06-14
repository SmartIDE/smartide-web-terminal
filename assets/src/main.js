import Vue from 'vue';
import contentmenu from 'v-contextmenu'
import 'v-contextmenu/dist/index.css'
import ElementUI from 'element-ui'
import App from './App.vue';
 
Vue.use(contentmenu);
Vue.use(ElementUI);

Vue.prototype.$message = ElementUI.Message;


new Vue({
    el: '#terminal',
    render: h => h(App)
});

