import React from 'react';
import Svg, { Circle, Path, Rect } from 'react-native-svg';

/**
 * Icon set traced 1:1 from the approved design's inline SVGs —
 * same viewBoxes, paths, stroke weights, and caps.
 */
interface IconProps {
  size?: number;
  color: string;
}

export function SearchIcon({ size = 18, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={11} cy={11} r={7} stroke={color} strokeWidth={2} strokeLinecap="round" />
      <Path d="M16.5 16.5 21 21" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function FilterIcon({ size = 17, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M4 6h16M7 12h10M10 18h4" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function HomeIcon({ size = 22, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M3 10.5 12 3l9 7.5"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path
        d="M5.5 9.5V21h13V9.5"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

export function CalendarIcon({ size = 22, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Rect x={3} y={5} width={18} height={17} rx={3} stroke={color} strokeWidth={2} />
      <Path d="M3 10h18M8 3v4M16 3v4" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function PlayersIcon({ size = 22, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={9} cy={8} r={3.5} stroke={color} strokeWidth={2} />
      <Path d="M3 20c0-3.3 2.7-6 6-6s6 2.7 6 6" stroke={color} strokeWidth={2} strokeLinecap="round" />
      <Circle cx={17} cy={9} r={2.5} stroke={color} strokeWidth={2} />
      <Path d="M16 14.6c2.5.4 4.5 2.6 4.5 5.4" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function ProfileIcon({ size = 22, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx={12} cy={8} r={4} stroke={color} strokeWidth={2} />
      <Path d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function SendIcon({ size = 19, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M4 12h14M13 6l6 6-6 6"
        stroke={color}
        strokeWidth={2.2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

export function CheckIcon({ size = 44, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M4.5 12.5 10 18 19.5 7"
        stroke={color}
        strokeWidth={3}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
}

export function CrossIcon({ size = 38, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path d="M6 6l12 12M18 6 6 18" stroke={color} strokeWidth={3} strokeLinecap="round" />
    </Svg>
  );
}

export function EyeIcon({ size = 19, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M2.5 12c2.2-4.6 5.9-7 9.5-7s7.3 2.4 9.5 7c-2.2 4.6-5.9 7-9.5 7s-7.3-2.4-9.5-7Z"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Circle cx={12} cy={12} r={3} stroke={color} strokeWidth={2} />
    </Svg>
  );
}

export function EyeOffIcon({ size = 19, color }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M4.5 8.6C3.7 9.5 3 10.7 2.5 12c2.2 4.6 5.9 7 9.5 7 1.6 0 3.2-.5 4.7-1.4M9.5 5.4C10.3 5.1 11.1 5 12 5c3.6 0 7.3 2.4 9.5 7-.5 1.1-1.1 2.1-1.8 2.9"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
      <Path d="M4 4l16 16" stroke={color} strokeWidth={2} strokeLinecap="round" />
    </Svg>
  );
}

export function WifiOffIcon({ size = 40, color, slashColor }: IconProps & { slashColor: string }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M2 9c5.5-5 14.5-5 20 0M5.5 12.5c3.6-3.2 9.4-3.2 13 0M9 16c1.7-1.5 4.3-1.5 6 0"
        stroke={color}
        strokeWidth={2}
        strokeLinecap="round"
      />
      <Circle cx={12} cy={19} r={1.3} fill={color} />
      <Path d="M4 4l16 16" stroke={slashColor} strokeWidth={2.4} strokeLinecap="round" />
    </Svg>
  );
}
