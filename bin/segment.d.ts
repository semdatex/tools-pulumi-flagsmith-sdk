import * as pulumi from "@pulumi/pulumi";
import * as inputs from "./types/input";
import * as outputs from "./types/output";
export declare class Segment extends pulumi.CustomResource {
    /**
     * Get an existing Segment resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: SegmentState, opts?: pulumi.CustomResourceOptions): Segment;
    /**
     * Returns true if the given object is an instance of Segment.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is Segment;
    /**
     * Description of the segment
     */
    readonly description: pulumi.Output<string | undefined>;
    /**
     * Set this to create a feature specific segment
     */
    readonly featureId: pulumi.Output<number>;
    /**
     * Name of the segment
     */
    readonly name: pulumi.Output<string>;
    /**
     * ID of the project
     */
    readonly projectId: pulumi.Output<number>;
    /**
     * UUID of project the segment belongs to
     */
    readonly projectUuid: pulumi.Output<string>;
    /**
     * Rules for the segment
     */
    readonly rules: pulumi.Output<outputs.SegmentRule[]>;
    /**
     * ID of the segment
     */
    readonly segmentId: pulumi.Output<number>;
    /**
     * UUID of the segment
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a Segment resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: SegmentArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering Segment resources.
 */
export interface SegmentState {
    /**
     * Description of the segment
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * Set this to create a feature specific segment
     */
    featureId?: pulumi.Input<number | undefined>;
    /**
     * Name of the segment
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * ID of the project
     */
    projectId?: pulumi.Input<number | undefined>;
    /**
     * UUID of project the segment belongs to
     */
    projectUuid?: pulumi.Input<string | undefined>;
    /**
     * Rules for the segment
     */
    rules?: pulumi.Input<pulumi.Input<inputs.SegmentRule>[] | undefined>;
    /**
     * ID of the segment
     */
    segmentId?: pulumi.Input<number | undefined>;
    /**
     * UUID of the segment
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a Segment resource.
 */
export interface SegmentArgs {
    /**
     * Description of the segment
     */
    description?: pulumi.Input<string | undefined>;
    /**
     * Set this to create a feature specific segment
     */
    featureId?: pulumi.Input<number | undefined>;
    /**
     * Name of the segment
     */
    name?: pulumi.Input<string | undefined>;
    /**
     * UUID of project the segment belongs to
     */
    projectUuid: pulumi.Input<string>;
    /**
     * Rules for the segment
     */
    rules: pulumi.Input<pulumi.Input<inputs.SegmentRule>[]>;
}
//# sourceMappingURL=segment.d.ts.map