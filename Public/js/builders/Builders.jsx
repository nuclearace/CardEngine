import React, { Component } from 'react';
import { BuildersGame } from './components';

export class Builders extends Component {
    render() {
        return (
            <div className='Builders'>
                <h1> The Builders </h1>
                <BuildersGame />
            </div>
        );
    }
}
