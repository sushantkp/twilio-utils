import { h, Component } from 'preact';
import style from './style';

import Toggle from '../../components/Toggle';


export default class Home extends Component {
	render() {
		return (
			<div class={style.home}>
				<Toggle />
			</div>
		);
	}
}
