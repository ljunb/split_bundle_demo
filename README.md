## split_bundle_demo

网上已有很多关于 `bundle` 拆分的资料，自己也是做了参考。目前主要是针对 `react-native bundle` 命令的拆分，实际官方支持 `react-native ram-bundle`（旧：`react-native unbundle`）命令，公司已有一套基于 `unbundle` 的拆包和按需加载封装，待有空继续研究。

### 简介
基于 `metro` 拆包的前置条件，其实是因为其打包命令支持接收 `--config some.config.js` 参数，在对应的配置文件中，针对以下两个参数进行改写：
> * `createModuleIdFactory`：用于生成每个 `module` 的唯一 ID，规则怎么定都可以，只要确保唯一
> * `processModuleFilter`：打包过滤命令，返回 `true` 代表需要打进 `bundle` 里面，否则忽略

### 流程
> * 自定义metro打包配置参数，先打 `common.bundle`，再以此为基础，打 `business.bundle`
> * App 启动时异步加载 `common.bundle`，此时也可以增加 `business.bundle` 的预加载功能
> * 当需要进入某个业务时，加载对应的 `business.bundle`

### Plan
- [x] 分包处理
- [x] 按需加载
- [ ] 路由管理
- [ ] 打包config文件优化以及cli支持
- [ ] ram-bundle 深入研究
- [ ] 热更相关

### 参考资源
* [React Native（二）：分包机制与动态下发](https://juejin.im/post/6844903922205736973#heading-5)
* [招商证券 react-native 热更新优化实践](https://www.infoq.cn/article/2VpEMoVuRxvqp1IzWvJl)
* [RAM Bundles 和内联引用优化](https://reactnative.cn/docs/ram-bundles-inline-requires)
