/**
 * Author      : linjb
 * Date        : 2020/9/14
 * Description :
 */
import * as React from 'react';
import {View, Text} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import RNRoute from '../../../RNRoute';

function HomeScreen({navigation}) {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
      }}>
      <Text>Home 业务模块</Text>
      <Text style={{marginTop: 20}} onPress={() => RNRoute.pop()}>
        Back to main screen
      </Text>
      <Text
        style={{marginTop: 20}}
        onPress={() => navigation.navigate('Detail')}>
        Open detail screen
      </Text>
    </View>
  );
}

function DetailScreen(props) {
  return (
    <View style={{flex: 1, alignItems: 'center', justifyContent: 'center'}}>
      <Text onPress={() => RNRoute.pop()}>Detail Screen</Text>
      <Text style={{marginTop: 20}}>Extra infos: {props.info}</Text>
    </View>
  );
}

const Stack = createStackNavigator();

function App(props) {
  const {initialRouteName = 'Home'} = props;
  // todo：不同business页面传参
  alert(JSON.stringify(props));
  return (
    <NavigationContainer>
      <Stack.Navigator initialRouteName={initialRouteName}>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Detail" component={DetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
