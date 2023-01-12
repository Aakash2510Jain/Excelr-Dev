import { LightningElement,api } from 'lwc';

export default class IndexchildLWC extends LightningElement {
    
    @api indexchild;

    get position() {
        return indexchild + 1;
    }
}