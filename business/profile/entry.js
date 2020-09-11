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

export default class Profile extends PureComponent {
  render() {
    return (
      <View style={styles.container}>
        <Text>Profile</Text>
      </View>
    );
  }
}
