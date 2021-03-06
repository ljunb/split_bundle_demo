const fs = require('fs');
const path = require('path');
const pathSep = path.sep;

let comDepFiles = [];
let comDepSet = null;
const checkCommonDependency = (depPath) => {
  const outputsPath = `${process.cwd()}${pathSep}outputs${pathSep}`;
  const commonDepPath = `${outputsPath}common_dependency`;
  const businessPath = `${outputsPath}business${pathSep}`;

  if (!fs.existsSync(businessPath)) {
    fs.mkdirSync(businessPath);
  }

  if (comDepSet === null && fs.existsSync(commonDepPath)) {
    // 获取基础包的依赖，保存到一个集合里面
    if (comDepFiles.length === 0) {
      comDepFiles = String(fs.readFileSync(commonDepPath))
        .split('\n')
        .filter((dep) => dep.length > 0);
    }
    comDepSet = new Set(comDepFiles);
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
