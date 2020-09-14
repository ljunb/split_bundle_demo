## split_bundle_demo

网上已有很多关于 `bundle` 拆分的资料，自己也是做了参考。目前主要是针对 `react-native bundle` 命令的拆分，实际官方支持 `react-native ram-bundle`（旧：`react-native unbundle`）命令，公司已有一套基于 `unbundle` 的拆包和按需加载封装，待有空继续研究。

### 简介
前置了解：
> 打包生成的文件结构

一个常见的 ReactNative 打包命令：
```shell script
react-native bundle --entry-file ./index.js --bundle-output ./outputs/main.jsbundle --dev false --platform ios
```
实际 ReactNative 打包 `bundle` 支持的命令参数还有很多，具体可以运行 `react-native bundle --help` 查看更多参数。在罗列出来的参数中，会有一个 `--config [string]` 的选项，实际该参数即是 Metro 中接收序列化配置的选项。具体参考 [Serializer Options](https://facebook.github.io/Metro/docs/configuration#serializer-options)。

在序列化的配置选项中，用于拆包的主要涉及到以下两个：
* `createModuleIdFactory`：用于生成每个 `module` 的 ID，规则怎么定都可以，只要确保唯一
* `processModuleFilter`：打包过滤命令，返回 `true` 代表需要打进 `bundle` 里面，否则忽略

### 流程
#### Metro 序列化设置
当我们想打不同的 `bundle` 的时候，将会在打包命令上增加 `--config some.config.js` 来区分。比如打基础包时：
```shell script
react-native bundle --entry-file ./index.js --config ./common.config.js --bundle-output ./outputs/main.jsbundle --dev false --platform ios
```

至此，在对序列化配置选项以及不同打包命令有个大概了解后，接下来可以简单地梳理下拆包流程。

先是 `common.bundle`：
* 新增针对基础包的配置文件 `common.config.js`，命名随意
* 配置文件最终导出的是 `{ serializer: { createModuleIdFactory, processModuleFilter }`
* `createModuleIdFactory` 选项只要保证生成唯一 ID 即可
* `processModuleFilter` 选项是用于过滤 `module` 的，在判断该 `module` 符合基础包依赖的同时，将依赖唯一标识（这里取文件路径）写入本地，用于后续打业务包时过滤依赖

最终的文件内容（这里的规则与网上资料基本一致，自己只是稍作改动，只要理解做了什么就行）：
```javascript
// common.config.js
const fs = require('fs');
const path = require('path');
const pathSep = path.sep;

const makeCommonDependencyDir = (depPath) => {
  const outputsPath = `${process.cwd()}${pathSep}outputs`;
  // path: /User/linjb/split_bundle_demo/outputs/common_dependency
  const depFilePath = `${outputsPath}${pathSep}common_dependency`;
  // remove client user path
  const basename = path.basename(process.cwd());
  const writeDepPath = depPath.substr(depPath.indexOf(basename));

  if (fs.existsSync(outputsPath)) {
    fs.appendFileSync(depFilePath, `\n${writeDepPath}`);
  } else {
    fs.mkdirSync(outputsPath);
    fs.writeFileSync(depFilePath, writeDepPath);
  }
};

/**
 * A filter function to discard specific modules from the output.
 */
const processModuleFilter = (module) => {
  const modulePath = module.path;
  if (modulePath.indexOf('__prelude__') >= 0) {
    return false;
  }
  makeCommonDependencyDir(modulePath);
  return true;
};

/**
 * Used to generate the module id for require statements.
 */
const createModuleIdFactory = () => {
  const projectPath = process.cwd();

  return (modulePath) => {
    let moduleName = '';
    // react-native目录下的，取相对路径
    if (
      modulePath.indexOf(
        `node_modules${pathSep}react-native${pathSep}Libraries${pathSep}`,
      ) > 0
    ) {
      moduleName = modulePath.substr(modulePath.lastIndexOf(pathSep) + 1);
    } else if (modulePath.indexOf(projectPath) === 0) {
      // 当前项目下的业务代码
      moduleName = modulePath.substr(projectPath.length + 1);
    }
    moduleName = moduleName.replace('.js', '');
    moduleName = moduleName.replace('.png', '');
    const regExp = new RegExp(pathSep === '\\' ? '\\\\' : pathSep, 'gm');
    moduleName = moduleName.replace(regExp, '_');

    return moduleName;
  };
};

module.exports = {
  serializer: {
    createModuleIdFactory,
    processModuleFilter,
  },
};
```

而业务包的配置文件，也基本差不多，主要会做一个依赖过滤的操作：
```javascript
// business.config.js
const fs = require('fs');
const path = require('path');
const pathSep = path.sep;

let comDepSet = null;
const checkCommonDependency = (depPath) => {
  const outputsPath = `${process.cwd()}${pathSep}outputs${pathSep}`;
  const commonDepPath = `${outputsPath}common_dependency`;
  const businessPath = `${outputsPath}business${pathSep}`;

  if (!fs.existsSync(businessPath)) {
    fs.mkdirSync(businessPath);
  }

  // TODO：待优化，每次都生成一个set了
  if (comDepSet === null && fs.existsSync(commonDepPath)) {
    // 获取基础包的依赖，保存到一个集合里面
    const depPaths = String(fs.readFileSync(commonDepPath))
      .split('\n')
      .filter((dep) => dep.length > 0);
    comDepSet = new Set(depPaths);
  } else if (comDepSet === null) {
    comDepSet = new Set();
  }

  const basename = path.basename(process.cwd());
  const writeDepPath = depPath.substr(depPath.indexOf(basename));
  return comDepSet.has(writeDepPath);
};

/**
 * A filter function to discard specific modules from the output.
 */
const processModuleFilter = (module) => {
  const modulePath = module.path;
  if (modulePath.indexOf('__prelude__') >= 0) {
    return false;
  }

  return !checkCommonDependency(modulePath);
};

/**
 * Used to generate the module id for require statements.
 */
const createModuleIdFactory = () => {
  const projectPath = process.cwd();

  return (modulePath) => {
    let moduleName = '';
    // react-native目录下的，取相对路径
    if (
      modulePath.indexOf(
        `node_modules${pathSep}react-native${pathSep}Libraries${pathSep}`,
      ) > 0
    ) {
      moduleName = modulePath.substr(modulePath.lastIndexOf(pathSep) + 1);
    } else if (modulePath.indexOf(projectPath) === 0) {
      // 当前项目下的业务代码
      moduleName = modulePath.substr(projectPath.length + 1);
    }
    moduleName = moduleName.replace('.js', '');
    moduleName = moduleName.replace('.png', '');
    const regExp = new RegExp(pathSep === '\\' ? '\\\\' : pathSep, 'gm');
    moduleName = moduleName.replace(regExp, '_');

    return moduleName;
  };
};

module.exports = {
  serializer: {
    createModuleIdFactory,
    processModuleFilter,
  },
};
```
到此完成 Metro 命令相关的支持，可以把相关打包命令添加到 `package.json` 的 `scripts` 中，方便命令执行：
```json
{
  "scripts": {
    "build-common": "react-native bundle --entry-file ./common.js --config ./common.config.js --bundle-output ./outputs/common.bundle --dev false",
    "build-home": "react-native bundle --entry-file ./business/home/entry.js --config business.config.js --bundle-output ./outputs/business/home.bundle --dev false",
    "build-profile": "react-native bundle --entry-file ./business/profile/entry.js --config business.config.js --bundle-output ./outputs/business/profile.bundle --dev false"
  }
}
```
最终打包结果 `common.bundle` 大小为 767KB，`home.bundle` 和 `profile.bundle` 都为 2KB。具体文件位置 [common.js](https://github.com/ljunb/split_bundle_demo/blob/master/common.js)、[home.js](https://github.com/ljunb/split_bundle_demo/blob/master/business/home/entry.js) 和 [profile.js](https://github.com/ljunb/split_bundle_demo/blob/master/business/profile/entry.js) 。

#### Native 端支持
分包我们已经完成，接下来需要增加 Native 端的支持。按一开始分包后的预期，是实现基础包的预加载，然后在进入具体业务页面的时候，再按需加载对应的业务 `bundle`。

在有一个基础思路的指引后，可以新增一个针对 ReactNative 简单管理的类 [ReactNativeManager](https://github.com/ljunb/split_bundle_demo/blob/master/ios/split_bundler_demo/RNSplitter/ReactNativeManager.h) 以及专门管理 `bundle` 加载的类 [RNBundleLoader](https://github.com/ljunb/split_bundle_demo/blob/master/ios/split_bundler_demo/RNSplitter/RNBundleLoader.h)，简单梳理如下：
* 移除 AppDelegate 中的 RCTBridgeDelegate 代理方法 `- sourceURLForBridge:`
* ReactNativeManager 中持有全局单例 RCTBridge，同时实现 `- sourceURLForBridge` 代理方法，返回基础包的 `URL`
* RNBundleLoader 监听 `RCTJavaScriptDidLoadNotification` 通知，当加载完基础包后将会触发该通知，如果有需要预加载的业务包，则进行加载
* 业务包的加载需要用到 RCTJavaScriptLoader 的 `+ loadBundleAtURL:onProgress:onComplete:`，并在结束回调中，执行 RCTCxxBridge 的 `- executeSourceCode:sync:` 方法加载 JavaScript 脚本（这里需要新建 RCTBridge 分类，暴露出`- executeSourceCode:sync:` 方法，注：分类方法的查找流程，如果分类没有实现，最终将查找到其宿主类的方法列表）
* RNBundleLoader 保留一份已加载过的 `bundle` 记录，如果已经加载过，那么就不再加载，这样可以避免 JavaScript 脚本加载结束通知 `RCTJavaScriptDidLoadNotification` 的循环触发
* ReactNativeManager 暴露创建 RCTRootView 的方法 `- setupRootViewWithBundleName:launchOptions:complete:`，如果 `bundle` 加载成功或加载过，返回新建的实例；否则返回 `nil`

更具体的逻辑可以查看源码。

#### 示例运行
```shell script
git clone https://github.com/ljunb/split_bundle_demo.git
cd split_bundle_demo && npm install
cd ios && pod install

npm run build-common
npm run build-home
npm run build-profile
```
然后运行工程即可。

### Plan
- [x] 分包处理
- [x] 按需加载
- [x] 调试相关
- [x] 路由管理
- [ ] 打包config文件优化以及cli支持
- [ ] ram-bundle 深入研究
- [ ] 热更相关

### 参考资源
* [React Native（二）：分包机制与动态下发](https://juejin.im/post/6844903922205736973#heading-5)
* [招商证券 react-native 热更新优化实践](https://www.infoq.cn/article/2VpEMoVuRxvqp1IzWvJl)
* [RAM Bundles 和内联引用优化](https://reactnative.cn/docs/ram-bundles-inline-requires)
