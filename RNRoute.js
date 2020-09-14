/**
 * Author      : linjb
 * Date        : 2020/9/14
 * Description :
 */

import {NativeModules} from 'react-native';

const RNRouteManager = NativeModules.RNRouteManager;

export default class RNRoute {
  static pop = () => RNRouteManager.pop();

  static navigate = (routeName, params) =>
    RNRouteManager.navigate(routeName, params);
}
