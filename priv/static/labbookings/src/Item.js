import React, { Component } from 'react';
import 'semantic-ui-css/semantic.min.css';
import { Card, Icon, Button } from 'semantic-ui-react'


// ----------------------------------------------------------------------------------------------------
// Details about the item
// ----------------------------------------------------------------------------------------------------
class Item extends Component
{
    constructor(props) {
        super (props);
        this.state = {
            link : window.location.protocol + "//" + window.location.hostname + ":" + window.location.port + "/?item=" + this.props.name
        }
    }

    handleClick = () => {
        window.location = this.state.link;
    }

    handleMap = () => {
        window.location = this.props.mapurl;
    }

    render ()
    {
        return (
            <Card color='blue'>
                <Button icon fluid basic onClick={this.handleClick}>
                    <Card.Content>
                        <Icon color='blue' name='university' size='massive'/>
                        <Card.Header as="h2">{this.props.name}</Card.Header>
                        <Card.Meta>
                            {this.props.campus}
                        </Card.Meta>
                    </Card.Content>
                </Button>

                <Card.Content>
                    <Button icon fluid basic onClick={this.handleMap}>
                        <Icon color='blue' name='map'/>
                        Map
                    </Button>
                </Card.Content>
            </Card>
        )
    }
}

export default Item;
// ----------------------------------------------------------------------------------------------------
