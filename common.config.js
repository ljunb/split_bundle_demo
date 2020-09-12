const fs = require('fs');
const pathSep = require('path').sep;

const makeCommonDependencyDir = (path) => {
  const depPath = `${process.cwd()}${pathSep}outputs`;
  // path: /User/linjb/split_bundle_demo/outputs/common_dependency
  const depFilePath = `${depPath}${pathSep}common_dependency`;
  if (fs.existsSync(depPath)) {
    fs.appendFileSync(depFilePath, `\n${path}`);
  } else {
    fs.mkdirSync(depPath);
    fs.writeFileSync(depFilePath, path);
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
