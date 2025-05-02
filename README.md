# Custom Build ImmortalWrt

## 🤔 这是什么？
它是一个利用GitHub Actions快速构建带docker且支持自定义大小的ImmortalWrt固件。

> 1、支持自定义固件大小。默认1GB <br>
> 2、支持预安装docker（可选）<br>
> 3、目前支持x86-64平台<br>
> 4、新增支持MT3000（docker可选）<br>
> 5、新增用户预设置pppoe拨号功能<br>


## 如何查询都有哪些插件?
https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/23.05.4/packages/aarch64_cortex-a53/luci/ <br>
https://mirrors.sjtug.sjtu.edu.cn/immortalwrt/releases/23.05.4/packages/x86_64/luci/ <br>
**查询不到的就是不能编译的。**

## 该固件默认属性？(必读)
可通过 `99-custom.sh` 配置和调整部分设置。

# 🌟鸣谢
### https://github.com/immortalwrt
### https://github.com/wukongdaily/AutoBuildImmortalWrt
