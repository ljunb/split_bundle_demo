/**
 * Author      : linjb
 * Date        : 2020/9/14
 * Description :
 */
import 'react-native-gesture-handler';
import * as React from 'react';
import {View, Text} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import RNRoute from '../../../routes/RNRoute';

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
        onPress={() => navigation.navigate('HomeDetail')}>
        Open detail screen
      </Text>
    </View>
  );
}

function DetailScreen({route}) {
  const {params = {}} = route;
  return (
    <View style={{flex: 1, alignItems: 'center', justifyContent: 'center'}}>
      <Text onPress={() => RNRoute.pop()}>Detail Screen</Text>
      <Text style={{marginTop: 20}}>Extra infos: {params.info}</Text>
    </View>
  );
}

const Stack = createStackNavigator();

function App(props) {
  const {initialRouteName = 'Home'} = props;

  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName={initialRouteName}
        screenOptions={{headerShown: false}}>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          initialParams={props}
        />
        <Stack.Screen
          name="HomeDetail"
          component={DetailScreen}
          initialParams={props}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
