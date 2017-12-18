import { h, Component } from 'preact';
import { Pulsate } from 'styled-loaders';

import style from './style';

import Toggle from '../../components/Toggle';
import ConfigForm from '../../components/ConfigForm';


export default class Home extends Component {

	constructor(props) {
		super(props);

		this.state = {
			status: false,
			loading: true
		};

		this.toggleStatus = this.toggleStatus.bind(this);
	}


	render(props, state) {
		return (
		<section class={style.home}>
			{state.loading ?
			
				this.renderLoading()
				
			:
			
				<div>

					<Toggle
						status={state.status}
						toggleStatus={this.toggleStatus} />

					<ConfigForm />

				</div>
			}
		</section>);
	}


	renderLoading() {
		return (
		<div class={style.loaderContainer}>
			<Pulsate color="#673AB7" />
		</div>);
	}


	componentDidMount() {
		setTimeout(() => {
			this.setLoading(false);
		}, 1000);
	}


	setLoading(bool) {
		this.setState({loading: bool});
	}


	toggleStatus() {
		this.setLoading(true);

		setTimeout(() => {
			this.setLoading(false);
			this.setState({status: !this.state.status});
		}, 1000);
	}

}
