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
