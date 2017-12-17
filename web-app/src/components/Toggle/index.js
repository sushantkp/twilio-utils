import { h, Component } from 'preact';
import style from './style';


export default class Toggle extends Component {

    constructor(props) {
        super(props);

        this.state = {
            status: true
        };
    }


    render(props, state) {
        return (
        <div class={style.root}>

            <span>Script Status : </span>

            <span class={style.value}>{state.status ? 'enabled' : 'disabled'}</span>

            <span class={style.button}>{state.status ? 'disable' : 'enable'}</span>

        </div>);
    }


    componentDidMount() {
        
    }

}