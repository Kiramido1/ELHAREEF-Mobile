import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { DarkTheme, DefaultTheme, NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import React from 'react';
import { TabBar } from '../components/TabBar';
import { BookingDetailsScreen } from '../screens/BookingDetailsScreen';
import { BookingScreen } from '../screens/BookingScreen';
import { BookingsScreen } from '../screens/BookingsScreen';
import { ChatScreen } from '../screens/ChatScreen';
import { ConfirmedScreen } from '../screens/ConfirmedScreen';
import { CreateMatchScreen } from '../screens/CreateMatchScreen';
import { DiscoverScreen } from '../screens/DiscoverScreen';
import { FindPlayersScreen } from '../screens/FindPlayersScreen';
import { ForgotPasswordScreen } from '../screens/ForgotPasswordScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { LoginScreen } from '../screens/LoginScreen';
import { MatchDetailsScreen } from '../screens/MatchDetailsScreen';
import { MatchFullScreen } from '../screens/MatchFullScreen';
import { MyMatchesScreen } from '../screens/MyMatchesScreen';
import { NotificationsScreen } from '../screens/NotificationsScreen';
import { OfflineScreen } from '../screens/OfflineScreen';
import { OnboardingScreen } from '../screens/OnboardingScreen';
import { PaymentFailedScreen } from '../screens/PaymentFailedScreen';
import { PitchDetailsScreen } from '../screens/PitchDetailsScreen';
import { PlayerProfileScreen } from '../screens/PlayerProfileScreen';
import { ProfileScreen } from '../screens/ProfileScreen';
import { SearchScreen } from '../screens/SearchScreen';
import { SettingsScreen } from '../screens/SettingsScreen';
import { SignupScreen } from '../screens/SignupScreen';
import { SplashScreen } from '../screens/SplashScreen';
import { SummaryScreen } from '../screens/SummaryScreen';
import { useTheme } from '../theme';
import { MainTabParamList, RootStackParamList } from './types';

const Stack = createNativeStackNavigator<RootStackParamList>();
const Tabs = createBottomTabNavigator<MainTabParamList>();

function MainTabs() {
  return (
    <Tabs.Navigator
      screenOptions={{ headerShown: false }}
      tabBar={(props) => <TabBar {...props} />}
    >
      <Tabs.Screen name="Home" component={HomeScreen} />
      <Tabs.Screen name="Discover" component={DiscoverScreen} />
      <Tabs.Screen name="Bookings" component={BookingsScreen} />
      <Tabs.Screen name="MyMatches" component={MyMatchesScreen} />
      <Tabs.Screen name="Profile" component={ProfileScreen} />
    </Tabs.Navigator>
  );
}

export function AppNavigator() {
  const { colors, dark } = useTheme();
  const navTheme = {
    ...(dark ? DarkTheme : DefaultTheme),
    colors: {
      ...(dark ? DarkTheme.colors : DefaultTheme.colors),
      background: colors.bg,
      card: colors.card,
      text: colors.ink,
      primary: '#24A551',
      border: colors.ink08,
    },
  };

  return (
    <NavigationContainer theme={navTheme}>
      <Stack.Navigator
        screenOptions={{
          headerShown: false,
          // Light and simple: a quick crossfade between screens.
          animation: 'fade',
          animationDuration: 200,
          gestureEnabled: true,
        }}
        initialRouteName="Splash"
      >
        <Stack.Screen name="Splash" component={SplashScreen} />
        <Stack.Screen name="Onboarding" component={OnboardingScreen} />
        <Stack.Screen name="Login" component={LoginScreen} />
        <Stack.Screen name="Signup" component={SignupScreen} />
        <Stack.Screen name="ForgotPassword" component={ForgotPasswordScreen} />
        <Stack.Screen name="Tabs" component={MainTabs} />
        <Stack.Screen name="Search" component={SearchScreen} />
        <Stack.Screen name="Pitch" component={PitchDetailsScreen} />
        <Stack.Screen name="Booking" component={BookingScreen} />
        <Stack.Screen name="Summary" component={SummaryScreen} />
        <Stack.Screen name="Confirmed" component={ConfirmedScreen} />
        <Stack.Screen name="FindPlayers" component={FindPlayersScreen} />
        <Stack.Screen name="CreateMatch" component={CreateMatchScreen} />
        <Stack.Screen name="MatchDetails" component={MatchDetailsScreen} />
        <Stack.Screen name="MatchFull" component={MatchFullScreen} />
        <Stack.Screen name="PlayerProfile" component={PlayerProfileScreen} />
        <Stack.Screen name="Chat" component={ChatScreen} />
        <Stack.Screen name="BookingDetails" component={BookingDetailsScreen} />
        <Stack.Screen name="Notifications" component={NotificationsScreen} />
        <Stack.Screen name="Settings" component={SettingsScreen} />
        <Stack.Screen name="PaymentFailed" component={PaymentFailedScreen} />
        <Stack.Screen name="Offline" component={OfflineScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
