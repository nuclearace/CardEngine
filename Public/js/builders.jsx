import React, { Component } from 'react';

export class BuildersGame extends Component {
    constructor(props) {
        super(props);

        this.ws = new WebSocket('ws://localhost:8080/join');

        this.ws.addEventListener('open', () => {
            this.ws.send(JSON.stringify({'game': 'TheBuilders'}));
        });

        this.ws.addEventListener('message', event => {
            this.setState((prev) => {
                let messages = prev.messages;

                messages.push(event.data);

                return {
                    messages: messages
                }
            });
        });

        this.state = {};
        this.state.messages = [];
    }

    render() {
        return (
            <MessageList messages={this.state.messages}/>
        )
    }
}

function MessageList(props) {
    const messages = props.messages;
    const list = messages.map(message => {
        return <li key={Math.random()}>{message}</li>
    });

    return <ul>{list}</ul>
}
