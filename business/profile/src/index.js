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

function HomeScreen() {
  return (
    <View
      style={{
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
      }}>
      <Text>Profile 业务模块</Text>
      <Text style={{marginTop: 20}} onPress={() => RNRoute.pop()}>
        Back to main screen
      </Text>
      <Text
        style={{marginTop: 20}}
        onPress={() =>
          RNRoute.navigate('Detail', {info: 'from profile business'})
        }>
        Open detail screen of home business
      </Text>
    </View>
  );
}

function DetailScreen() {
  return (
    <View style={{flex: 1, alignItems: 'center', justifyContent: 'center'}}>
      <Text>Detail Screen</Text>
    </View>
  );
}

const Stack = createStackNavigator();

function App(props) {
  const {initialRouteName = 'ProfileHome'} = props;
  return (
    <NavigationContainer>
      <Stack.Navigator
        initialRouteName={initialRouteName}
        screenOptions={{headerShown: false}}>
        <Stack.Screen name="ProfileHome" component={HomeScreen} />
        <Stack.Screen name="ProfileDetail" component={DetailScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
