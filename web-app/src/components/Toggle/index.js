import { h, Component } from 'preact';
import style from './style';


export default class Toggle extends Component {

    constructor(props) {
        super(props);

        this.onClickToggle = this.onClickToggle.bind(this);
    }


    render(props, state) {
        return (
        <div class={style.root}>

            <span class={style.description}>Job Status</span>

            <span class={style.indicator + ' ' + (props.status ? style.indicatorGreen : style.indicatorRed)} />

            <span
                class={style.button + ' ' + (props.status ? style.buttonRed : style.buttonGreen)}
                onClick={this.onClickToggle}>

                {props.status ? 'disable' : 'enable'}

            </span>

        </div>);
    }


    componentDidMount() {
        
    }


    onClickToggle() {
        this.props.toggleStatus();
    }

}