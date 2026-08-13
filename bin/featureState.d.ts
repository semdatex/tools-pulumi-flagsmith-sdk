import * as pulumi from "@pulumi/pulumi";
import * as inputs from "./types/input";
import * as outputs from "./types/output";
export declare class FeatureState extends pulumi.CustomResource {
    /**
     * Get an existing FeatureState resource's state with the given name, ID, and optional extra
     * properties used to qualify the lookup.
     *
     * @param name The _unique_ name of the resulting resource.
     * @param id The _unique_ provider ID of the resource to lookup.
     * @param state Any extra arguments used during the lookup.
     * @param opts Optional settings to control the behavior of the CustomResource.
     */
    static get(name: string, id: pulumi.Input<pulumi.ID>, state?: FeatureStateState, opts?: pulumi.CustomResourceOptions): FeatureState;
    /**
     * Returns true if the given object is an instance of FeatureState.  This is designed to work even
     * when multiple copies of the Pulumi SDK have been loaded into the same process.
     */
    static isInstance(obj: any): obj is FeatureState;
    /**
     * Used for enabling/disabling the feature
     */
    readonly enabled: pulumi.Output<boolean>;
    /**
     * ID of the environment
     */
    readonly environmentId: pulumi.Output<number>;
    /**
     * Client side environment key associated with the environment
     */
    readonly environmentKey: pulumi.Output<string>;
    /**
     * ID of the feature
     */
    readonly featureId: pulumi.Output<number>;
    /**
     * ID of the feature_segment, used internally to bind a feature state to a segment
     */
    readonly featureSegmentId: pulumi.Output<number>;
    /**
     * ID of the featurestate
     */
    readonly featureStateId: pulumi.Output<number>;
    /**
     * Value for the feature State. NOTE: One of string_value,<span pulumi-lang-nodejs=" integerValue " pulumi-lang-dotnet=" IntegerValue " pulumi-lang-go=" integerValue " pulumi-lang-python=" integer_value " pulumi-lang-yaml=" integerValue " pulumi-lang-java=" integerValue " pulumi-lang-hcl=" integer_value "> integerValue </span>or<span pulumi-lang-nodejs=" booleanValue " pulumi-lang-dotnet=" BooleanValue " pulumi-lang-go=" booleanValue " pulumi-lang-python=" boolean_value " pulumi-lang-yaml=" booleanValue " pulumi-lang-java=" booleanValue " pulumi-lang-hcl=" boolean_value "> booleanValue </span>must be set
     */
    readonly featureStateValue: pulumi.Output<outputs.FeatureStateFeatureStateValue>;
    /**
     * ID of the segment, used for creating segment overrides
     */
    readonly segmentId: pulumi.Output<number | undefined>;
    /**
     * Priority of the segment overrides.
     */
    readonly segmentPriority: pulumi.Output<number>;
    /**
     * UUID of the featurestate
     */
    readonly uuid: pulumi.Output<string>;
    /**
     * Create a FeatureState resource with the given unique name, arguments, and options.
     *
     * @param name The _unique_ name of the resource.
     * @param args The arguments to use to populate this resource's properties.
     * @param opts A bag of options that control this resource's behavior.
     */
    constructor(name: string, args: FeatureStateArgs, opts?: pulumi.CustomResourceOptions);
}
/**
 * Input properties used for looking up and filtering FeatureState resources.
 */
export interface FeatureStateState {
    /**
     * Used for enabling/disabling the feature
     */
    enabled?: pulumi.Input<boolean | undefined>;
    /**
     * ID of the environment
     */
    environmentId?: pulumi.Input<number | undefined>;
    /**
     * Client side environment key associated with the environment
     */
    environmentKey?: pulumi.Input<string | undefined>;
    /**
     * ID of the feature
     */
    featureId?: pulumi.Input<number | undefined>;
    /**
     * ID of the feature_segment, used internally to bind a feature state to a segment
     */
    featureSegmentId?: pulumi.Input<number | undefined>;
    /**
     * ID of the featurestate
     */
    featureStateId?: pulumi.Input<number | undefined>;
    /**
     * Value for the feature State. NOTE: One of string_value,<span pulumi-lang-nodejs=" integerValue " pulumi-lang-dotnet=" IntegerValue " pulumi-lang-go=" integerValue " pulumi-lang-python=" integer_value " pulumi-lang-yaml=" integerValue " pulumi-lang-java=" integerValue " pulumi-lang-hcl=" integer_value "> integerValue </span>or<span pulumi-lang-nodejs=" booleanValue " pulumi-lang-dotnet=" BooleanValue " pulumi-lang-go=" booleanValue " pulumi-lang-python=" boolean_value " pulumi-lang-yaml=" booleanValue " pulumi-lang-java=" booleanValue " pulumi-lang-hcl=" boolean_value "> booleanValue </span>must be set
     */
    featureStateValue?: pulumi.Input<inputs.FeatureStateFeatureStateValue | undefined>;
    /**
     * ID of the segment, used for creating segment overrides
     */
    segmentId?: pulumi.Input<number | undefined>;
    /**
     * Priority of the segment overrides.
     */
    segmentPriority?: pulumi.Input<number | undefined>;
    /**
     * UUID of the featurestate
     */
    uuid?: pulumi.Input<string | undefined>;
}
/**
 * The set of arguments for constructing a FeatureState resource.
 */
export interface FeatureStateArgs {
    /**
     * Used for enabling/disabling the feature
     */
    enabled: pulumi.Input<boolean>;
    /**
     * Client side environment key associated with the environment
     */
    environmentKey: pulumi.Input<string>;
    /**
     * ID of the feature
     */
    featureId: pulumi.Input<number>;
    /**
     * Value for the feature State. NOTE: One of string_value,<span pulumi-lang-nodejs=" integerValue " pulumi-lang-dotnet=" IntegerValue " pulumi-lang-go=" integerValue " pulumi-lang-python=" integer_value " pulumi-lang-yaml=" integerValue " pulumi-lang-java=" integerValue " pulumi-lang-hcl=" integer_value "> integerValue </span>or<span pulumi-lang-nodejs=" booleanValue " pulumi-lang-dotnet=" BooleanValue " pulumi-lang-go=" booleanValue " pulumi-lang-python=" boolean_value " pulumi-lang-yaml=" booleanValue " pulumi-lang-java=" booleanValue " pulumi-lang-hcl=" boolean_value "> booleanValue </span>must be set
     */
    featureStateValue: pulumi.Input<inputs.FeatureStateFeatureStateValue>;
    /**
     * ID of the segment, used for creating segment overrides
     */
    segmentId?: pulumi.Input<number | undefined>;
    /**
     * Priority of the segment overrides.
     */
    segmentPriority?: pulumi.Input<number | undefined>;
}
//# sourceMappingURL=featureState.d.ts.map