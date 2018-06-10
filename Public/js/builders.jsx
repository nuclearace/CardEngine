import React, { Component } from 'react';

export class BuildersGame extends Component {
    constructor(props) {
        super(props);

        this.ws = new WebSocket('ws://localhost:8080/join');

        this.ws.addEventListener('open', () => {
            this.ws.send(JSON.stringify({'game': 'TheBuilders'}));
        });

        this.ws.addEventListener('message', event => {
            this.parseMessage(JSON.parse(event.data));
        });

        this.state = {};
        this.state.turn = null;
        this.state.messages = [];
        this.state.hand = [];
    }

    parseMessage(messageObject) {
        switch (messageObject['type']) {
        case 'turnStart':
            console.log('start turn');
            break;
        case 'turn':
            this.parseTurn(messageObject['interaction']);
            break;
        default:
            console.log(`didn't handle ${JSON.stringify(messageObject)}`);
            break;
        }
    }

    parseTurn(turnObject) {
        switch (turnObject['phase']) {
        case 'play':
            this.setState({turn: 'play', hand: turnObject['hand']});
            break;
        default:
            console.error(`unhandled turn ${JSON.stringify(turnObject)}`);
        }
    }

    render() {
        switch (this.state.turn) {
        case 'play':
            return <PlayerHand hand={this.state.hand} />;
        default:
            return <h2>'Waiting!'</h2>;
        }
    }
}

class PlayerHand extends Component {
    render() {
        return (
            <ul>
                {this.props.hand.map((card, i) => {
                    return <PlayerCard key={i} card={card}/>;
                })}
            </ul>
        )
    }
}

class PlayerCard extends Component {
    render() {
        const type = this.props.card.playType;

        return (
            <li>
                <span>
                    {/*TODO figure out how to actually play this*/}
                    <button>Play</button>
                    Type {type}
                </span>
            </li>
        )
    }
}
