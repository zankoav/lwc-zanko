import { LightningElement, api, track } from 'lwc';

const CLASS_NAME_CONTENT = 'accordion-item';
const CLASS_NAME_CONTENT_ACTIVE = 'accordion-item_active';
const ACTIVE = 'active';

export default class FcAccordionItem extends LightningElement {

    @api active;
    @track className;

    contentView;
    contentViewHeight;
    currentContentViewHeight;
    isAnimating;

    toogleSlide() {
        if(!this.isAnimating){
            this.active = this.active === ACTIVE ? null : ACTIVE;
            this.update();
            this.withAnimation(this.animationFinish);
        }
    }


    withAnimation(callBackFinish) {
        this.isAnimating = true;
        this.contentView.style.display = 'block';
        const height = this.contentView.offsetHeight;
        this.contentView.style.overflow = 'hidden';
        let currentHeight = height;
        let opening = this.active === ACTIVE;
        if(opening){
            currentHeight = 0;
        }
        this.contentView.style.height = `${currentHeight}px`;
    
        let animate = () => {
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            requestAnimationFrame(()=>{
                if(opening){
                    currentHeight +=6;
                    if(currentHeight < height){
                        animate();
                        this.contentView.style.height = `${currentHeight}px`;
                    }else{
                        currentHeight = height;
                        this.isAnimating = false;
                        this.contentView.style.height = `${currentHeight}px`;
                        this.contentView.removeAttribute('style');
                        callBackFinish();
                    }
                }else{
                    currentHeight -=6;
                    if(currentHeight > 0){
                        animate();
                        this.contentView.style.height = `${currentHeight}px`;
                    }else{
                        currentHeight = 0;
                        this.contentView.style.height = `${currentHeight}px`;
                        this.isAnimating = false;
                        this.contentView.removeAttribute('style');
                        callBackFinish();
                    }
                }
                
            });
        };
        animate();
    }

    animationFinish() {
        console.log('animationFinish');
    }

    connectedCallback() {
        this.update();
    }

    renderedCallback() {
        this.contentView = this.template.querySelector('.accordion-item__content');
    }

    update() {
        this.className = this.active === ACTIVE ? `${CLASS_NAME_CONTENT} ${CLASS_NAME_CONTENT_ACTIVE}` : CLASS_NAME_CONTENT;
    }
}