/**
 * Author      : linjb
 * Date        : 2020/9/11
 * Description :
 */
import React, {PureComponent} from 'react';
import {StyleSheet, View, Text} from 'react-native';

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});

export default class Home extends PureComponent {
  render() {
    return (
      <View style={styles.container}>
        <Text>Home</Text>
      </View>
    );
  }
}
